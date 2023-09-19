package com.apple.federation.pkl.locks;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.graph.Graph;
import com.google.common.graph.GraphBuilder;
import com.google.common.graph.ImmutableGraph;
import com.google.common.graph.MutableGraph;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static java.nio.charset.StandardCharsets.UTF_8;

public class GenerateLock {
    public static final Type MAP_TYPE = new TypeToken<Map<String, Object>>() {
    }.getType();
    private final Downloader downloader;

    private final Set<Pattern> MODULE_LOCATORS = ImmutableSet.of(
        Pattern.compile("^amend\\s+\"(.*?)\""),
        Pattern.compile("^extends\\s*\"(.*?)\""),
        Pattern.compile("^import\\s*\"(.*?)\""));
    private final Function<String, Module> FIND_MODULE = str ->
        MODULE_LOCATORS.stream()
            .map(pattern -> pattern.matcher(str))
            .filter(Matcher::find)
            .map(matcher -> new Module(matcher.group(1)))
            .findFirst()
            .orElse(null);


    public static void main(String[] args) throws IOException {
        Gson gson = new GsonBuilder().setPrettyPrinting().disableJdkUnsafe().create();

        Path path = Paths.get(args[0]);
        Map<String, Object> params;

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            params = gson.fromJson(reader, MAP_TYPE);
        }

        String hash = (String) params.get("hash");
        @SuppressWarnings("unchecked")
        Collection<String> requested = (Collection<String>) params.get("deps");
        @SuppressWarnings("unchecked")
        Map<String, String> repos = (Map<String, String>) params.get("repos");

        GenerateLock generateLock = new GenerateLock();
        Graph<DownloadedModule> dependencyGraph = generateLock.prepareLockFile(
            ImmutableMap.copyOf(repos),
            requested.stream().map(Module::new).collect(Collectors.toSet()));

        ImmutableMap.Builder<String, Object> contents = ImmutableMap.builder();

        Map<String, String> modules = new TreeMap<>();
        dependencyGraph.nodes().forEach(dm -> modules.put(dm.module.toString(), dm.sha256));
        contents.put("__THIS_IS_A_GENERATED_FILE", "DO NOT EDIT BY HAND, PLEASE");
        contents.put("modules", modules);
        contents.put("hash", hash);
        contents.put("version", "1");

        System.out.println(gson.toJson(contents.build()));
    }

    static String sha256(Path file) throws IOException {
        byte[] buffer = new byte[8192];
        int count;
        MessageDigest digest;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Unable to find sha256 message digest");
        }
        try (InputStream is = Files.newInputStream(file);
             BufferedInputStream bufferedInputStream = new BufferedInputStream(is)) {
            while ((count = bufferedInputStream.read(buffer)) > 0) {
                digest.update(buffer, 0, count);
            }
        }

        // sha256 is always 64 characters.
        StringBuilder hexString = new StringBuilder(64);

        // Convert digest byte array to a hex string.
        for (byte b : digest.digest()) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }

        return hexString.toString();
    }

    public GenerateLock() {
        Netrc netrc = Netrc.fromUserHome();
        this.downloader = new Downloader(netrc);
    }

    private Graph<DownloadedModule> prepareLockFile(Map<String, String> repos, Set<Module> dependencies) throws IOException {
        Set<Module> toVisit = new HashSet<>(dependencies);
        Set<Module> visited = new HashSet<>();

        MutableGraph<DownloadedModule> graph = GraphBuilder.directed().build();

        while (!toVisit.isEmpty()) {
            Module module = toVisit.iterator().next();
            toVisit.remove(module);

            if (!visited.add(module)) {
                continue;
            }

            DownloadedModule source = getNode(graph, module);
            Path file = download(repos, module);
            source.setSha256(sha256(file));

            graph.addNode(source);
            Set<Module> deps = getDependencies(module, file);

            for (Module dep : deps) {
                DownloadedModule target = new DownloadedModule(dep);
                graph.addNode(target);

                // It's legal for a dependency to import itself. A self-import
                // enables referring to types consistently with the module's name,
                // in the same way they're referred to in users of the module.
                // We don't want to add self-loops. Guard against this. We can't
                // tell in advance whether adding an edge will introduce a loop,
                // but the graph will throw an exception if it does. Catch that &
                // silently ignore it, continue on as if nothing bad happened.
                // While this may make the generated graph wonky, this will be
                // exposed to users as either uncached entries or build errors
                // which can be resolved by adding additional dependencies.
                try {
                    graph.putEdge(source, target);
                } catch (IllegalArgumentException e) {
                    // The javadocs for `putEdge` say this will be only be thrown
                    // if we've introduced a loop.
                    System.err.printf(
                        "Unable to add edge in dependency graph between %s and %s%n",
                        source.module,
                        target.module);
                }
            }

            deps.stream()
                .filter(dep -> !visited.contains(dep))
                .forEach(toVisit::add);
        }

        return ImmutableGraph.copyOf(graph);
    }

    private DownloadedModule getNode(Graph<DownloadedModule> graph, Module module) {
        for (DownloadedModule node : graph.nodes()) {
            if (node.module.equals(module)) {
                return node;
            }
        }
        return new DownloadedModule(module);
    }

    private Set<Module> getDependencies(Module dep, Path file) throws IOException {
        Set<Module> toReturn = new HashSet<>();

        List<String> lines = Files.readAllLines(file, UTF_8);

        for (String line : lines) {
            line = line.trim();

            Module module = FIND_MODULE.apply(line);

            if (module == null) {
                continue;
            }

            if (module.getVersion() == null) {
                module = new Module(module.toFullyQualifiedModuleString() + ":" + dep.getVersion());
            }

            // Any URI with a `pkl` scheme refers to the standard lib, and is supplied by Pkl
            if (!"pkl".equals(module.getRepositoryName())) {
                toReturn.add(module);
            }
        }

        return toReturn;
    }

    private Path download(Map<String, String> repos, Module module) throws IOException {
        String baseUri = repos.get(module.getRepositoryName());
        if (baseUri == null) {
            throw new IllegalArgumentException("Unable to find mapping for scheme in module " + module);
        }

        // url = "{repo}{module_name}/{version}/{simple_name}-{version}.pkl"

        String rawUri = String.format("%s%s/%s/%s-%s.pkl",
            baseUri,
            module.getModuleName(),
            module.getVersion(),
            module.getSimpleName(),
            module.getVersion());

        return downloader.download(URI.create(rawUri));
    }

    private static class DownloadedModule {
        private final Module module;
        private String sha256;

        public DownloadedModule(Module module) {
            this.module = module;
        }

        public void setSha256(String sha256) {
            this.sha256 = sha256;
        }

        @Override
        public String toString() {
            return module.toString() + ":" + (sha256 == null ? "unknown-sha" : sha256);
        }

        @Override
        public boolean equals(Object o) {
            if (!(o instanceof DownloadedModule)) {
                return false;
            }
            DownloadedModule that = (DownloadedModule) o;

            // These are equal if they represent the same module
            return module.equals(that.module);
        }

        @Override
        public int hashCode() {
            return Objects.hash(module);
        }
    }
}
