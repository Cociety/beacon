import AbstractPopoverController from "./abstract_popover_controller";
export default class QuickViewController extends AbstractPopoverController {
  get selector() {
    return '#quick_view';
  }

  get srcUrl() {
    return `/goals/${encodeURIComponent(this.idValue)}/quick_view`;
  }
}
