package team.kalpeva.poc.shopping;

import io.vertx.core.AbstractVerticle;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.BodyHandler;
import team.kalpeva.poc.shopping.comm.handlers.OrderRestHandlerImpl;

import static io.vertx.core.http.HttpMethod.POST;

public class MainVerticle extends AbstractVerticle {

  public static final int PORT = 8888;

/*
  @Override
  public void start(Promise<Void> startPromise) throws Exception {
    vertx.createHttpServer().requestHandler(req -> {
      req.response()
        .putHeader("content-type", "text/plain")
        .end("Hello from Vert.x!");
    }).listen(8888, http -> {
      if (http.succeeded()) {
        startPromise.complete();
        System.out.println("HTTP server started on port 8888");
      } else {
        startPromise.fail(http.cause());
      }
    });
  }
*/
  @Override
  public void start() throws Exception {
    // Create a Router
    Router router = Router.router(vertx);
    router.route().handler(BodyHandler.create());

    // Mount the handler for all incoming requests at every path and HTTP method
    /*router.route(GET, "/orders").handler(context -> {
      // Get the address of the request
      String address = context.request().connection().remoteAddress().toString();
      // Get the query parameter "name"
      MultiMap queryParams = context.queryParams();
      String name = queryParams.contains("name") ? queryParams.get("name") : "unknown";
      // Write a json response
      context.json(
          new JsonObject()
              .put("name", name)
              .put("address", address)
              .put("message", "Hello " + name + " connected from " + address)
      );
    });*/

    // Mount the handler for all incoming requests at every path and HTTP method
    router.route(POST,"/orders").handler(new OrderRestHandlerImpl());

    // Create the HTTP server
    vertx.createHttpServer()
        // Handle every request using the router
        .requestHandler(router)
        // Start listening
        .listen(PORT)
        // Print the port
        .onSuccess(server ->
            System.out.println(
                "HTTP server started on port " + server.actualPort()
            )
        );
  }
}