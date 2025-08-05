package team.boolbee.poc.cadence.entities;

public class SignaledWorkflowStatus {
    private boolean isSignalProcessed;
    private boolean isSignalReceived;
    private boolean isWorkflowRunning;
    private String runId;

    public boolean isSignalProcessed() {
        return isSignalProcessed;
    }

    public void setSignalProcessed(boolean signalProcessed) {
        isSignalProcessed = signalProcessed;
    }

    public boolean isSignalReceived() {
        return isSignalReceived;
    }

    public void setSignalReceived(boolean signalReceived) {
        isSignalReceived = signalReceived;
    }

    public boolean isWorkflowRunning() {
        return isWorkflowRunning;
    }

    public void setWorkflowRunning(boolean workflowRunning) {
        isWorkflowRunning = workflowRunning;
    }

    public String getRunId() {
        return runId;
    }

    public void setRunId(String runId) {
        this.runId = runId;
    }
}