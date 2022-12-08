package team.boolbee.poc.cadence.entities.activities;

import com.uber.cadence.testing.WorkflowReplayer;
import org.junit.Test;
import team.boolbee.poc.cadence.entities.workflows.GreetingWorkflow;

public class GreetingActivitiesReplayTest {

    /* This replay test is the recommended way to make sure changing workflow code is backward compatible
    without non-deterministic errors. "HelloActivity.json" can be downloaded from cadence CLI:
        cadence --do samples-domain wf show -w <workflow_id> --output_filename <filename>.json
    Or from Cadence Web UI. (You may need to put history file in resources folder; and change workflowType
    in the first event of history).
    */
    @Test
    public void testReplay() throws Exception {
        WorkflowReplayer.replayWorkflowExecutionFromResource(
                "greeting-workflow.json", GreetingWorkflow.class);
    }
}