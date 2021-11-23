import { Controller } from 'stimulus';
import BeaconApi from "../beacon_api";

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
  static SELECTED_CLASSES = ['shadow-lg', "scale-105", "-translate-x-20"];
  initialize() {
    this.paintParentsOfBlockedChildren();
    this.childGoalId = null;
    this.beaconApi = new BeaconApi();

    this.goalTargets.forEach(goal => {
      new Taps(goal);
      goal.addEventListener('doubletap', this.selectGoalToMove.bind(this), false);
      goal.addEventListener('tap', this.moveGoal.bind(this), false);
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
    const childGoalId = this.#goalId(event);
    const sameGoal = this.childGoalId === childGoalId;
    if (sameGoal) {
      this.childGoalId = null;
      event.target.classList.remove(...TreeController.SELECTED_CLASSES);
      this.showStartMessage()
    } else {
      this.childGoalId = this.#goalId(event);
      event.target.classList.add(...TreeController.SELECTED_CLASSES);
      this.showMoveMessage();
    }
  }

  moveGoal(event) {
    const parentGoalId = this.#goalId(event);
    if (this.childGoalId) {
      if (parentGoalId !== this.childGoalId) {
        this.beaconApi.adopt(parentGoalId, this.childGoalId);
        this.showStartMessage();
      }
    } else {
      event.detail.stopListening();
      event.detail.$el.querySelector('a').click();
    }
  }

  showMoveMessage() {
    this.tap_to_move_messageTarget.classList.remove('hidden');
    this.double_tap_to_start_messageTarget.classList.add('hidden');
  }

  showStartMessage() {
    this.double_tap_to_start_messageTarget.classList.remove('hidden');
    this.tap_to_move_messageTarget.classList.add('hidden');
  }

  #goalId(event) {
    return event.target.dataset['goal-id'];
  }
}