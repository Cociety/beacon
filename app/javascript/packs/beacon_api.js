import { ajax } from "@rails/ujs";

export default class BeaconApi {
  /**
   * Adds goal as a parent of childGoal
   * @param {*} goalId 
   * @param {*} childGoalId 
   */
  adopt(goalId, childGoalId) {
    ajax({
      url: `/goals/${encodeURIComponent(goalId)}/adopt/${encodeURIComponent(childGoalId)}`,
      type: 'PUT'
    });
  }
}