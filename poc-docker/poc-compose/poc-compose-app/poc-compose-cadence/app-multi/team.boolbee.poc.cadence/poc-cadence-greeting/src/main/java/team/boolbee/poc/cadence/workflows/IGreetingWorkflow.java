package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

import static team.boolbee.poc.cadence.Constants.TASK_LIST;

public interface IGreetingWorkflow {
    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 10, taskList = TASK_LIST)
    String getGreeting(String name);
}