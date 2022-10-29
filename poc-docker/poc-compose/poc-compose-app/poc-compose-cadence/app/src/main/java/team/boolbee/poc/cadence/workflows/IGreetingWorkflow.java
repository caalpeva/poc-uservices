package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingWorkflow {
    @WorkflowMethod
    String greeting(String username);
}