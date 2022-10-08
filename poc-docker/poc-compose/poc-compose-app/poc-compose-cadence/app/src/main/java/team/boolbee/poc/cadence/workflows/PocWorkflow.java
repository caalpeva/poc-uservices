package team.boolbee.poc.cadence.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface PocWorkflow {
    @WorkflowMethod
    void greeting(String name);
}