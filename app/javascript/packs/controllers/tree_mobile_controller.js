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

export default class TreeMobileController extends Controller {
  static targets = [ "goal", "double_tap_to_start_message", "tap_to_move_message" ];
  initialize() {
    this.childGoalId = null;
    this.beaconApi = new BeaconApi();

    this.goalTargets.forEach(goal => {
      new Taps(goal);
      goal.addEventListener('doubletap', this.doubleTapped.bind(this), false);
      goal.addEventListener('tap', this.tapped.bind(this), false);
    });
  }

  doubleTapped(event) {
    const childGoalId = this.#goalId(event);
    const sameGoal = this.childGoalId === childGoalId;
    if (sameGoal) {
      this.childGoalId = null;
      event.target.style.transform = '';
      event.target.classList.remove(...['shadow-md', 'border-2', 'border-indigo-600']);
      this.showStartMessage()
    } else {
      this.childGoalId = this.#goalId(event);
      event.target.style.transform = 'scale(1.05, 1.05)';
      event.target.classList.add(...['shadow-md', 'border-2', 'border-indigo-600']);
      this.showMoveMessage();
    }
  }

  tapped(event) {
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