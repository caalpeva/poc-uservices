package team.kalpeva.activity.inventory;

import team.boolbee.poc.cadence.entities.CadenceManager;

public class Main {

  private final static String CADENCE_DOMAIN = "poc-shopping";
  private final static String TASKLIST = "tl-activities-inventory-v1";

  public static void main(String[] args) {
    CadenceManager cadenceManager = new CadenceManager();
    cadenceManager.startWorker(cadenceManager.createDefaultWorkflowClient(CADENCE_DOMAIN),
            TASKLIST,
            new InventoryActivityImpl());

    System.out.println("ACTIVITY STARTED!");
  }
}