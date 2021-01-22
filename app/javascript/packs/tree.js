import { drag, hierarchy, linkVertical, select, selectAll, tree } from "d3";
import { ajax, delegate } from "@rails/ujs";
export default class Tree {
  constructor(options = {}) {
    this.options = {
      width: 400,
      height: 200,
      nodeRadius: 14,
      ...options
    };
    this.isDragging = false;
    this.newParent = null;
    this.isInitialized = false;
    this.turboFrame = document.querySelector('turbo-frame#goals');
  }

  getVisibleContextMenus() {
    return document.querySelectorAll('[id^=context-menu-][class*="opacity-100"]');
  }

  isContextMenuVisible() {
    return !!this.getVisibleContextMenus().length;
  }

  hideContextMenus() {
    this.getVisibleContextMenus().forEach(menu => {
      menu.classList.add('hidden');
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
    element.classList.remove('hidden');
    setTimeout(() => {
      element.classList.add('opacity-100');
    });
  }

  draw() {
    const content = document.getElementById("content");
    this.data = JSON.parse(content.dataset.goal)
    if (!this.isInitialized) {
      this.isInitialized = true;

      // close context menu when clicking outside of it or pressing escape
      delegate(document.body, { selector: '*', exclude: '[id^=context-menu-]' }, 'mousedown', () => {
        if (this.isContextMenuVisible()) {
          this.hideContextMenus();
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
        .call(drag()
          .on("start", function(event) { self.dragStarted(event, this); })
          .on("drag", function(event) { self.drag(event, this); })
          .on("end", function(event) { self.dragEnd(event, this); })
        )
        .on('mouseenter', function(event) { self.mouseEnter(event, this); })
        .on('mouseleave', function(event) { self.mouseLeave(event, this); })
        .on('contextmenu', function(event) {
          event.preventDefault();
          const circle = select(this);
          const goalId = circle.datum().data.id;
          self.showContextMenu(`#context-menu-${goalId}`, event.offsetX, event.offsetY);
        });

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
        const state = node.datum().data.state;
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
      .style("stroke-width", d => d.target.data.duration || 1)
      .attr("id", d => `link_${d.source.data.id}_${d.target.data.id}`)
      .join("path")
        .attr("d", linkVertical()
            .x(d => d.x)
            .y(d => d.y));
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

  dragStarted(event, g) {
    this.isDragging = true;
    const descendants = event.subject.descendants();
    this.nodesBeingDrug = [
      ...descendants.map(d => select(`#node_${d.data.id}`)),
      ...descendants.map(d => selectAll(`[id^="link_${d.data.id}"]`))
    ];
    this.nodesBeingDrug.forEach(n => n.classed("dragging", true).raise());
  }
  
  drag(event) {
    this.nodesBeingDrug.forEach(n => n.attr("transform", `translate(${event.x - event.subject.x}, ${event.y - event.subject.y})`));
  }

  dragEnd(_, g) {
    this.isDragging = false;
    if (this.newParent) {
      const svg = select(g);
      this.soleParent(svg.datum().data.id, this.newParent.datum().data.id);
    } else {
      this.nodesBeingDrug.forEach(n => {
        n.attr("transform", null);
      });
    }

    this.nodesBeingDrug.forEach(n => n.classed("dragging", false));
    this.resetNewParent();
  }

  mouseEnter(_, g) {
    if (this.isDragging) {
      this.newParent = select(g);
      this.newParent.classed('hovering', true);
      const t = this.newParent.transition().duration(150);
      this.newParent
        .transition(t)
        .attr("transform", d => `translate(${d.x}, ${d.y}) scale(1.1, 1.1) translate(${-d.x}, ${-d.y})`);
    }
  }

  mouseLeave() {
    if (this.isDragging) {
      this.resetNewParent();
    }
  }

  resetNewParent() {
    if (this.newParent) {
      this.newParent.classed('hovering', false);
      const t = this.newParent.transition().duration(150);
      // this.newParent.classed('hovering', false);
      this.newParent
        .transition(t)
        .attr("transform", 'scale(1)');
      this.newParent = null;
    }
  }

  soleParent(goalId, newParentId) {
    ajax({
      url: `/goals/${encodeURIComponent(goalId)}/sole_parent/${encodeURIComponent(newParentId)}`,
      type: 'PUT',
      success: data => {
        fulfill(data);
      }
    });
  }
}
