package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

import static team.boolbee.poc.cadence.entities.CadenceConstants.TASK_LIST_GREETING;

public interface IGreetingWorkflow {
    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 10)
    String getGreeting(String name);
}