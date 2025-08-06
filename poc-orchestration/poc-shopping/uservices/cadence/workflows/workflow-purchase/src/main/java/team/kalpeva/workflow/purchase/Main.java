package team.kalpeva.workflow.purchase;

import team.boolbee.poc.cadence.entities.CadenceManager;

public class Main {

  private final static String CADENCE_DOMAIN = "poc-shopping";
  private final static String TASKLIST = "tl-workflow-purchase-v1";

  public static void main(String[] args) {
    CadenceManager cadenceManager = new CadenceManager();
    //cadenceManager.registerDomain(CADENCE_DOMAIN);
    cadenceManager.startWorker(cadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN),
            TASKLIST,
            PurchaseWorkflow.class);

    System.out.println("ACTIVITY STARTED!");
  }
}