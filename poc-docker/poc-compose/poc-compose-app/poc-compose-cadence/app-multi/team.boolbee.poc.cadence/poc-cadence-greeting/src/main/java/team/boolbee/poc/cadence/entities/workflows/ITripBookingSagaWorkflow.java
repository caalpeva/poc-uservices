package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.WorkflowMethod;

public interface ITripBookingSagaWorkflow {
    @WorkflowMethod(executionStartToCloseTimeoutSeconds = 3600)
    void bookTrip(String name, boolean asynchCancellation);
}