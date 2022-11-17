package team.boolbee.poc.cadence.entities.workflows;

import com.uber.cadence.workflow.QueryMethod;
import com.uber.cadence.workflow.SignalMethod;
import com.uber.cadence.workflow.WorkflowMethod;

import java.util.List;

public interface IGreetingWorkflowWithSignals {
    /**
     * @return list of greeting strings that were received through the waitForNameMethod. This
     *     method will block until the number of greetings specified are received.
     */
    @WorkflowMethod
    List<String> getGreetings();

    /** Receives name through an external signal. */
    @SignalMethod
    void waitForName(String name);

    @SignalMethod
    void exit();
}