package com.apple.federation.pcl.symlinks;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Map;

class Symlinks {
    private static final Type MAP_TYPE = new TypeToken<Map<String, String>>() { }.getType();

    private Symlinks() {
    }

    public static void main(String[] args) throws IOException {
        if (args.length < 1) {
            throw new RuntimeException("Expected the first argument to be a path to a symlinks JSON file.");
        }

        var jsonFile = args[0];

        if (!Files.exists(Paths.get(args[0]))) {
            throw new RuntimeException("No symlinks JSON file exists at " + jsonFile);
        }

        try (
            FileReader file = new FileReader(jsonFile, StandardCharsets.UTF_8);
            BufferedReader buf = new BufferedReader(file);
        ) {
            var gson = new Gson();
            Map<String, String> symlinks = gson.fromJson(buf, MAP_TYPE);

            for (Map.Entry<String, String> entry : symlinks.entrySet()) {
                var target = Paths.get(entry.getKey()).toAbsolutePath().normalize();
                var link = Paths.get(entry.getValue()).toAbsolutePath().normalize();

                if (Files.exists(link)) {
                    continue;
                }

                Files.createDirectories(link.getParent());
                Files.createSymbolicLink(link, target);
            }
        }
    }
}
