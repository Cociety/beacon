import { Controller } from 'stimulus';
import BeaconApi from "../beacon_api";

export default class TreeMobileController extends Controller {
  initialize() {
    this.childGoalId = null;
    this.beaconApi = new BeaconApi();

    this.element.querySelectorAll('.js-draggable').forEach(goal => {
      // workaround for iOS10/iOS11 touchmove behaviour (https://github.com/timruffles/mobile-drag-drop/issues/77)
      try {
        window.addEventListener('touchmove', function () {
        }, {passive: false})
    } catch(e) {}
      goal.addEventListener('dragstart', this.dragStarted.bind(this), false);
      goal.addEventListener('dragend', this.dragEnd.bind(this), false);
    });

    this.element.querySelectorAll('.js-dropzone').forEach(goal => {
      goal.addEventListener('dragenter', this.dragEntered.bind(this), false);
      goal.addEventListener('dragleave', this.dragLeave.bind(this), false);
      goal.addEventListener('dragover', this.dragover);
      goal.addEventListener('drop', this.drop.bind(this), false);
    });
  }

  dragStarted(e) {
    e.stopPropagation();
    this.childGoalId = this.#goalId(e.currentTarget);
    e.dataTransfer.setData("text/plain", this.childGoalId);
  }

  dragEntered(e) {
    e.stopPropagation();
    e.preventDefault();
    if (this.#isDroppable(e)) {
      e.target.style.transform = 'scale(1.05, 1.05)';
    }
  }

  dragLeave(e) {
    e.stopPropagation();
    e.preventDefault();
    if (this.#isDroppable(e)) {
      e.target.style.transform = '';
    }
  }

  dragover(e) {
    // required for 'drop' event to fire
    e.stopPropagation();
    e.preventDefault();
  }

  dragEnd(e) {
    e.preventDefault();
    e.stopPropagation();
    this.childGoalId = null;
  }

  drop(e){
    e.preventDefault();
    if (this.#isDroppable(e)) {
      this.beaconApi.adopt(this.#goalId(e.target), this.childGoalId);
      this.childGoalId = null;
    }
  }

  #goalId(element){
    return element.dataset['goal-id'];
  }

  #isDroppable(e) {
    return this.childGoalId && e.target.classList.contains('js-dropzone') && this.#goalId(e.target) !== this.childGoalId;
  }
}