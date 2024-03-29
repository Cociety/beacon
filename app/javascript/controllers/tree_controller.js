import { Controller } from '@hotwired/stimulus';
import BeaconApi from "beacon/api";

class Taps {
  constructor($el) {
    this.$el = $el;
    this.timeout = null;
    this.clickHandler = this.clicked.bind(this);
    this.startListening();
  }

  clicked(event) {
    event.stopPropagation();
    event.preventDefault();
    if (this.isDouble) {
      this.#endTap(new CustomEvent('doubletap', {detail: this}));
    } else {
      this.timeout = setTimeout(() => {
        this.#endTap(new CustomEvent('tap', {detail: this}));
      }, 300);
    }
  }

  get isDouble() {
    return this.timeout !== null;
  }

  startListening() {
    this.$el.addEventListener('click', this.clickHandler, false);
  }

  stopListening() {
    this.$el.removeEventListener('click', this.clickHandler, false);
  }

  #endTap(event) {
    clearTimeout(this.timeout);
    this.timeout = null;
    this.$el.dispatchEvent(event);
  }
}

export default class TreeController extends Controller {
  static targets = [ "goal", "double_tap_to_start_message", "tap_to_move_message", "form" ];
  static SELECTED_CLASSES = ['shadow-lg', "scale-110", "-translate-x-20", "z-10"];
  initialize() {
    this.paintParentsOfBlockedChildren();
    this.childGoal = null;
    this.beaconApi = new BeaconApi();

    this.goalTargets.forEach(goal => {
      new Taps(goal);
      goal.addEventListener('doubletap', this.selectGoalToMove.bind(this), false);
      goal.addEventListener('tap', this.moveOrPropogateEvent.bind(this), false);
    });
  }

  paintParentsOfBlockedChildren() {
    this.element.querySelectorAll('li.blocked').forEach(blockedGoal => {
      let e = blockedGoal;
      while(e !== this.element) {
        e = e.parentNode;
        e.classList.add('blocked');
      }
    });
  }

  selectGoalToMove(event) {
    const childGoal = this.#goal(event);
    const childGoalId = this.#goalId(childGoal);
    const sameGoal = this.#goalId(this.childGoal) === childGoalId;
    if (sameGoal) {
      this.childGoal = null;
      childGoal.classList.remove(...TreeController.SELECTED_CLASSES);
      this.showStartMessage()
    } else {
      if (this.childGoal) {
        this.childGoal.classList.remove(...TreeController.SELECTED_CLASSES);
      }
      this.childGoal = childGoal;
      this.childGoal.classList.add(...TreeController.SELECTED_CLASSES);
      this.showMoveMessage();
    }
  }

  moveOrPropogateEvent(event) {
    const parentGoal = this.#goal(event);
    const parentGoalId = this.#goalId(parentGoal);
    const childGoalId = this.#goalId(this.childGoal);
    if (childGoalId) {
      this.move(parentGoalId, childGoalId);
    } else {
      this.propogateClick(event);
    }
  }

  move(parentGoalId, childGoalId) {
    if (parentGoalId !== childGoalId) {
      this.beaconApi.adopt(parentGoalId, childGoalId);
      this.showStartMessage();
    }
  }

  propogateClick(event) {
    event.detail.stopListening();
    // this assumes the goal is wrapped in an anchor tag
    event.detail.$el.parentElement.click();
  }

  showMoveMessage() {
    this.tap_to_move_messageTarget.classList.remove('hidden');
    this.double_tap_to_start_messageTarget.classList.add('hidden');
  }

  showStartMessage() {
    this.double_tap_to_start_messageTarget.classList.remove('hidden');
    this.tap_to_move_messageTarget.classList.add('hidden');
  }

  #goalId(goal) {
    return goal?.dataset?.goalId;
  }

  #goal(event) {
    return event.target;
  }
}