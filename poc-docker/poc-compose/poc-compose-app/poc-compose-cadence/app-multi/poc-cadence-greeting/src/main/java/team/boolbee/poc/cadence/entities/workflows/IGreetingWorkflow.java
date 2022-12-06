package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingWorkflow {
    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 20)
    String getGreeting(String name);
}