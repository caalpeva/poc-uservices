package team.kalpeva.poc.shopping.handlers;

import io.vertx.core.Handler;
import io.vertx.ext.web.RoutingContext;
import io.vertx.core.json.JsonObject;
import com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException;
import io.vertx.core.json.DecodeException;

public class GenericFailureHandler implements Handler<RoutingContext> {

  @Override
  public void handle(RoutingContext ctx) {
    Throwable failure = ctx.failure();
    int statusCode = 500;

    String code = "INTERNAL_ERROR";
    String message = "Ha ocurrido un error inesperado.";
    JsonObject details = new JsonObject();

    if (failure != null) {
      if (failure instanceof UnrecognizedPropertyException) {
        statusCode = 400;
        code = "UNKNOWN_PROPERTY";
        message = "Propiedad JSON no reconocida.";
        UnrecognizedPropertyException upe = (UnrecognizedPropertyException) failure;
        details.put("property", upe.getPropertyName());

      } else if (failure instanceof DecodeException) {
        statusCode = 400;
        code = "MALFORMED_JSON";
        message = "El cuerpo de la solicitud no es un JSON válido.";
        details.put("error", failure.getMessage());
      } else {
        // Otros errores no controlados
        statusCode = 500;
        code = "INTERNAL_ERROR";
        message = failure.getMessage() != null ? failure.getMessage() : message;
      }
    }

    JsonObject errorResponse = new JsonObject()
            .put("code", code)
            .put("message", message)
            .put("details", details);

    ctx.response()
            .setStatusCode(statusCode)
            .putHeader("Content-Type", "application/json")
            .end(errorResponse.encodePrettily());
  }
}
