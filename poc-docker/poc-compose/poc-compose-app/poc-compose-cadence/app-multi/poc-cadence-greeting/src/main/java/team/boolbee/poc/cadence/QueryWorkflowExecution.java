package team.boolbee.poc.cadence;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import team.boolbee.poc.cadence.entities.CadenceManager;

import static team.boolbee.poc.cadence.Constants.CADENCE_DOMAIN;

public class QueryWorkflowExecution {
    private static Logger logger = LoggerFactory.getLogger(QueryWorkflowExecution.class);

    public static void main(String[] args) {
        //CadenceManager.registerDomain(CADENCE_DOMAIN);
        String queryType="";
        String workflowId="266c83ac-7d3e-4a43-87d7-a70dc297f355";
        String runId="0086506e-b0d6-4b1d-a821-e68cd3ea61e6";
        //CadenceManager.queryWorkflowExecution
        String result = CadenceManager.printWorkflowExecutionHistory(
                CADENCE_DOMAIN,
                queryType,
                workflowId,
                runId);

        System.out.println("Query result for " + workflowId + ":");
        System.out.println(result);

        System.exit(0);
    }
}