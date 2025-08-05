package team.kalpeva.poc.shopping.verticle;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Handler;
import io.vertx.core.Promise;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.RoutingContext;
import io.vertx.ext.web.handler.BodyHandler;
import lombok.extern.slf4j.Slf4j;

import javax.inject.Inject;
import javax.inject.Named;

import static io.vertx.core.http.HttpMethod.POST;

@Slf4j
public class ShoppingVerticle extends AbstractVerticle {

    public static final int PORT = 9090;

    private final Handler<RoutingContext> handler;

    @Inject
    public ShoppingVerticle(@Named("shoppingRestHandler") Handler<RoutingContext> handler) {
        this.handler = handler;
    }

    @Override
    public void start(Promise<Void> startPromise) throws Exception {
        Router router = Router.router(vertx);
        router.route().handler(BodyHandler.create());
        router.route(POST, "/orders")
                .handler(BodyHandler.create())
                .handler(handler);

        vertx.createHttpServer().requestHandler(router)
                .listen(PORT, http -> {
                    if (http.succeeded()) {
                        startPromise.complete();
                        log.info("HTTP server started on port: {}", http.result().actualPort());
                    } else {
                        startPromise.fail(http.cause());
                    }
                });
    }
}