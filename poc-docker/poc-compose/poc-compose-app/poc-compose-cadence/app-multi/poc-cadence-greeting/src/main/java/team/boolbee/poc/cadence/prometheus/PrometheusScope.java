package team.boolbee.poc.cadence.prometheus;

import com.uber.m3.tally.*;
import com.uber.m3.util.ImmutableMap;

import java.util.Map;

/**
 * PrometheusScope will replace all "-"(dash) into "_"(underscore) so that it meets the requirement
 * in https://prometheus.io/docs/concepts/data_model/
 */
class PrometheusScope implements Scope {

  private Scope scope;

  PrometheusScope(Scope scope) {
    this.scope = scope;
  }

  private String fixName(String name) {
    String newName = name.replace('-', '_');
    return newName;
  }

  private Map<String, String> fixTags(Map<String, String> tags) {
    ImmutableMap.Builder<String, String> builder = new ImmutableMap.Builder<>();
    tags.forEach((key, value) -> builder.put(fixName(key), fixName(value)));
    return builder.build();
  }

  @Override
  public Counter counter(final String name) {
    String newName = fixName(name);
    return scope.counter(newName);
  }

  @Override
  public Gauge gauge(final String name) {
    String newName = fixName(name);
    return scope.gauge(newName);
  }

  @Override
  public Timer timer(final String name) {
    String newName = fixName(name);
    return scope.timer(newName);
  }

  @Override
  public Histogram histogram(final String name, final Buckets buckets) {
    String newName = fixName(name);
    return scope.histogram(newName, buckets);
  }

  @Override
  public Scope tagged(final Map<String, String> tags) {
    return new PrometheusScope(scope.tagged(fixTags(tags)));
  }

  @Override
  public Scope subScope(final String name) {
    String newName = fixName(name);
    return new PrometheusScope(scope.subScope(newName));
  }

  @Override
  public Capabilities capabilities() {
    return scope.capabilities();
  }

  @Override
  public void close() throws ScopeCloseException {
    scope.close();
  }
}