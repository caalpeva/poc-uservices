package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingParentWorkflow {
    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 20)
    String getGreeting(String name, boolean parallel);
}