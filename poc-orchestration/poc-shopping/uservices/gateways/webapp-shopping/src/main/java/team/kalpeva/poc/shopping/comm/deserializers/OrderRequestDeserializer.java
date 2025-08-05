package team.kalpeva.poc.shopping.comm.deserializers;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import team.kalpeva.poc.shopping.comm.requests.OrderRequest;

import java.io.IOException;

public class OrderRequestDeserializer {

  public OrderRequest from(String text) throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    return mapper.readValue(text, OrderRequest.class);
  }

}