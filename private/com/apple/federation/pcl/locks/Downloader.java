package com.apple.federation.pcl.locks;

import java.io.IOException;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.net.ProxySelector;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpResponse.BodyHandlers;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;

import static java.net.http.HttpClient.Redirect.ALWAYS;

public class Downloader {

    private final HttpClient client;

    public Downloader(Netrc netrc) {
        HttpClient.Builder builder =
            HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(300))
                .followRedirects(ALWAYS)
                .proxy(ProxySelector.getDefault());
        Authenticator authenticator =
            new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    String host = getRequestingHost();
                    Netrc.Credential credential = netrc.getCredential(host);
                    if (credential == null) {
                        return null;
                    }
                    return new PasswordAuthentication(
                        credential.account(), credential.password().toCharArray());
                }
            };
        builder = builder.authenticator(authenticator);
        this.client = builder.build();
    }

    public Path download(URI uri) throws IOException {
        HttpRequest request = HttpRequest.newBuilder(uri)
            .GET()
            .header("User-Agent", "Apple Federation rules_pcl")
            .timeout(Duration.ofMinutes(10))
            .build();

        Path file = Files.createTempFile("module", "pcl");

        try {
            HttpResponse.BodyHandler<Path> handler = BodyHandlers.ofFile(file);
            HttpResponse<Path> response = client.send(request, BodyHandlers.buffering(handler, 4096));
            if (response.statusCode() < 200 && response.statusCode() > 299) {
                throw new IOException("Unable to download " + uri);
            }
            return response.body();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException(e);
        }
    }
}
