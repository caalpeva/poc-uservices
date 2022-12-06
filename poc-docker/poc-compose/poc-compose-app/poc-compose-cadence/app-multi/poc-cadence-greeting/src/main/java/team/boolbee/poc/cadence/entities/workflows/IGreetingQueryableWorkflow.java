package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.QueryMethod;
import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingQueryableWorkflow {
    @WorkflowMethod
    void createGreeting(String name);

    /** Returns greeting as a query value. */
    @QueryMethod
    String queryGreeting();
}