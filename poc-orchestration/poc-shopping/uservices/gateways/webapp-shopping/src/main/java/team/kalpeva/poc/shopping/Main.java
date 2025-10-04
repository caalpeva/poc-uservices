package team.kalpeva.poc.shopping;

import io.vertx.core.Vertx;
import lombok.extern.slf4j.Slf4j;
import team.kalpeva.poc.shopping.di.DaggerDiComponent;

@Slf4j
public class Main {

    public static void main (String[] args) {
        Vertx vertx = Vertx.vertx();
        vertx.deployVerticle(DaggerDiComponent.create().mainVerticle())
                .onSuccess(id -> log.info("✅ Verticle deployed successfully, ID: {}", id))
                .onFailure(throwable -> log.error("❌ Failed to deploy verticle", throwable.getCause()));
    }
}