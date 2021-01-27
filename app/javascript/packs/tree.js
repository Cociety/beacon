import { hierarchy, linkVertical, select, tree } from "d3";
import { delegate } from "@rails/ujs";
import { dragHandler } from "./tree/drag";

export default class Tree {
  constructor(options = {}) {
    if (!options.selector) {
      throw new Error("selector option must be a string")
    }
    this.options = {
      height: 200,
      nodeRadius: 14,
      ...options
    };
    if ( !this.$el() ) {
      throw new Error("can't find $el on page");
    }

    this.isInitialized = false;
    this.turboFrame = document.querySelector('turbo-frame#goals');
    this.anyContextMenu = '[id^="context-menu-"]';
  }

  $el() {
    return document.querySelector(this.options.selector);
  }

  getVisibleContextMenus() {
    return document.querySelectorAll(`${this.anyContextMenu}[class*="opacity-100"]`);
  }

  isContextMenuVisible() {
    return !!this.getVisibleContextMenus().length;
  }

  hideContextMenus() {
    this.getVisibleContextMenus().forEach(menu => {
      menu.classList.add('hidden', 'opacity-0');
      setTimeout(() => {
        menu.classList.remove('opacity-100');
      });
    });
  }

  showContextMenu(selector, x, y) {
    this.hideContextMenus();
    const element = document.querySelector(selector);
    element.style.left = `${x}px`;
    element.style.top = `${y}px`;
    element.classList.remove('hidden', 'opacity-0');
    setTimeout(() => {
      element.classList.add('opacity-100');
    });
  }

  draw() {
    this.options.width = this.$el().offsetWidth;
    this.data = JSON.parse(this.$el().dataset.goal)
    if (!this.isInitialized) {
      this.isInitialized = true;
      const self = this;
      // close context menu when clicking outside of it or pressing escape
      delegate(document.body, '*', 'mousedown', function () {
        const menuClicked = this.matches(`${self.anyContextMenu} *, ${self.anyContextMenu}`);
        if (self.isContextMenuVisible() && !menuClicked) {
          self.hideContextMenus();
        }
      });
      delegate(document.body, '*', 'keydown', (e) => {
        if (this.isContextMenuVisible() && e.code === 'Escape' && !e.shiftKey && !e.ctrlKey) {
          this.hideContextMenus();
          return false;
        }
      });

      // re-render tree with new data after turbolinks updates the dom
      (new MutationObserver((mutationList) => {
        mutationList.forEach(m => {
          if (m.type === "childList") {
            this.draw();
          }
        })
      })).observe(this.turboFrame, {attributes: false, childList: true});

      // re-render on window resize
      window.addEventListener("resize", () => this.draw());
    }
    this.root = hierarchy(this.data);
    const treeLayout = tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    const {width, height, nodeRadius} = this.options;

    const viewBoxPadding = nodeRadius * 2;
    this.treeSvg = select('.tree')
      .attr('width', width + viewBoxPadding)
      .attr('height', height + viewBoxPadding)
      .attr('viewBox', `0 0 ${width + viewBoxPadding} ${height}`);

    this.treeSvg.selectAll("g.node").remove();
    this.treeSvg.selectAll("path.link").remove();
    this.datums = this.uniqueDatums();
    this.drawNodes();
    this.drawVertices();
  }

  drawNodes() {
    const self = this;
    this.nodes = this.treeSvg
      .select("g.nodes")
      .selectAll("g")
      .data(this.datums)
      .join("g")
        .classed("node", true)
        .attr("id", d => `node_${d.data.id}`)
        .call(dragHandler)
        .on('contextmenu', function(event) {
          event.preventDefault();
          const circle = select(this);
          const goalId = circle.datum().data.id;
          self.showContextMenu(`#context-menu-${goalId}`, event.clientX, event.clientY);
        })
        .each(function() {
          const node = select(this);
          node.datum().data.hasBlockedChildren = self.hasBlockedChildren(node.datum());
        })

    this.nodes
      .append("foreignObject")
      .attr("x", d => d.x - this.options.nodeRadius)
      .attr("y", d => d.y - this.options.nodeRadius)
      .attr('height', this.options.nodeRadius*2)
      .attr('width', this.options.nodeRadius*2)
      .append('xhtml:div')
      .classed('circle', true)
      .each(function() {
        const node = select(this);
        const data = node.datum().data;
        const state = data.hasBlockedChildren ? "blocked" : data.state;
        node.classed(state, true);
      })
      .append("xhtml:p")
      .classed("label", true)
      .html(d => `<span aria-hidden="true"></span>${d.data.name}`);
  }

  drawVertices() {
    this.treeSvg.select('g.links')
      .selectAll("path")
      .data(this.links())
      .enter()
      .append("path")
      .classed("link", true)
      .each(function() {
        const link = select(this);
        const data = link.datum().target.data;
        const state = data.hasBlockedChildren ? "blocked" : data.state;
        link.classed(state, true);
      })
      .style("stroke-width", d => d.target.data.duration || 1)
      .attr("id", d => `link_${d.source.data.id}_${d.target.data.id}`)
      .join("path")
        .attr("d", linkVertical()
            .x(d => d.x)
            .y(d => d.y));
  }

  hasBlockedChildren(datum) {
    if (datum.data.state === "blocked") {
      return true;
    }

    return (datum.children || []).reduce(
      (isBlocked, child) => this.hasBlockedChildren(child) || isBlocked,
      false
    );
  }

  uniqueDatums() {
    return Object.values(
      this.root.descendants().reduce((uniques, node) => {
        uniques[node.data.id] = node;
        return uniques;
      }, {})
    );
  }

  links() {
    return this.root.links(this.datums).map(l => {
      l.target = this.datums.find(n => n.data.id === l.target.data.id );
      return l;
    });
  }
}
