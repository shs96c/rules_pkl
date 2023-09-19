package com.apple.federation.pcl.locks;

import java.util.Objects;

public class Module {

    private final String repo;
    private final String moduleName;
    private final String simpleName;
    private final String version;

    public Module(String fullyQualified) {
        // Split the fully qualified name by separating on colons
        String[] parts = fullyQualified.split(":");

        if (parts.length !=2 && parts.length != 3) {
            throw new IllegalArgumentException("Expected fully qualified Pcl dep: " + fullyQualified);
        }

        this.repo = parts[0];
        this.moduleName = parts[1];

        int index = parts[1].lastIndexOf(".");
        this.simpleName = index == -1 ? parts[1] : parts[1].substring(index + 1);

        this.version = parts.length == 3 ? parts[2] : null;
    }

    public String getRepositoryName() {
        return repo;
    }

    public String getModuleName() {
        return moduleName;
    }

    public String getSimpleName() {
        return simpleName;
    }

    public String getVersion() {
        return version;
    }

    public String toFullyQualifiedModuleString() {
        return toString();
    }

    @Override
    public String toString() {
        StringBuilder str = new StringBuilder(repo).append(":").append(moduleName);
        if (version != null) {
            str.append(":").append(version);
        }
        return str.toString();
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Module)) {
            return false;
        }

        Module that = (Module) o;
        return repo.equals(that.repo) &&
            moduleName.equals(that.moduleName) &&
            version.equals(that.version);
    }

    @Override
    public int hashCode() {
        return Objects.hash(repo, moduleName, version);
    }
}
