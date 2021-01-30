import AbstractPopoverController from "./abstract_popover_controller";
export default class ContextMenuController extends AbstractPopoverController {
  get selector() {
    return '#context_menu';
  }

  get srcUrl() {
    return `/goals/${encodeURIComponent(this.idValue)}/context_menu`;
  }
}
