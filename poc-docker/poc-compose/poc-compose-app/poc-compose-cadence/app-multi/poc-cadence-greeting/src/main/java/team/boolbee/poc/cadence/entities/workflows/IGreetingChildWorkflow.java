package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface IGreetingChildWorkflow {
    @WorkflowMethod
    String composeGreeting(String greeting, String name);
  }