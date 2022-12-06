package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.QueryMethod;
import com.uber.cadence.workflow.SignalMethod;
import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingQueryableAndConsistentWorkflow {
    @WorkflowMethod
    void createGreeting(String name);

    @SignalMethod
    void increase();

    /** Returns greeting as a query value. */
    @QueryMethod
    int getCounter();
}