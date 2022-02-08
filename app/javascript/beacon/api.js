import Rails from "@rails/ujs";

export default class {
  /**
   * Adds goal as a parent of childGoal
   * @param {*} goalId 
   * @param {*} childGoalId 
   */
  adopt(goalId, childGoalId) {
    Rails.ajax({
      url: `/goals/${encodeURIComponent(goalId)}/adopt/${encodeURIComponent(childGoalId)}`,
      type: 'PUT'
    });
  }
}