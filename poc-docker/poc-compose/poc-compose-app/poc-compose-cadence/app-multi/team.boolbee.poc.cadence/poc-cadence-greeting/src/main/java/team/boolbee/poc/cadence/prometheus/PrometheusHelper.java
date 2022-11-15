package team.boolbee.poc.cadence.prometheus;

import com.uber.cadence.workflow.Workflow;
import com.uber.m3.tally.RootScopeBuilder;
import com.uber.m3.tally.Scope;
import com.uber.m3.tally.prometheus.PrometheusReporter;
import com.uber.m3.util.Duration;
import org.slf4j.Logger;

import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.exporter.HTTPServer;
import java.io.IOException;
import java.net.InetSocketAddress;

public class PrometheusHelper {
    private static Logger logger = Workflow.getLogger(PrometheusHelper.class);

    public static Scope createMetricScope() throws IOException {
        CollectorRegistry registry = CollectorRegistry.defaultRegistry;
        HTTPServer httpServer = new HTTPServer(new InetSocketAddress(9098), registry);
        PrometheusReporter reporter = PrometheusReporter.builder().registry(registry).build();

        // Make sure to set separator to "_" for Prometheus. Default is "." and doesn't work.
        Scope scope = new RootScopeBuilder()
                .separator("_")
                .reporter(reporter)
                .reportEvery(Duration.ofSeconds(1));

        return new PrometheusScope(scope);
    }
}