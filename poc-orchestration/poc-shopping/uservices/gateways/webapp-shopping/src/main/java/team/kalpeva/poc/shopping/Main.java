package team.kalpeva.poc.shopping;

import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;
import io.vertx.core.http.HttpServerOptions;
import io.vertx.micrometer.MicrometerMetricsOptions;
import io.vertx.micrometer.VertxPrometheusOptions;
import lombok.extern.slf4j.Slf4j;
import team.kalpeva.poc.shopping.di.DaggerDiComponent;

@Slf4j
public class Main {

    public static void main (String[] args) {
        var vertxPrometheusOptions =  new VertxPrometheusOptions()
                .setStartEmbeddedServer(true)
                .setEmbeddedServerOptions(new HttpServerOptions().setPort(9091))
                //.setEmbeddedServerEndpoint("/metrics/vertx")
                .setEnabled(true);

        Vertx vertx = Vertx.vertx(new VertxOptions()
                .setMetricsOptions(new MicrometerMetricsOptions()
                        .setPrometheusOptions(vertxPrometheusOptions)
                        .setEnabled(true)));

        vertx.deployVerticle(DaggerDiComponent.create().mainVerticle())
                .onSuccess(id -> log.info("✅ Verticle deployed successfully, ID: {}", id))
                .onFailure(throwable -> log.error("❌ Failed to deploy verticle", throwable.getCause()));
    }
}