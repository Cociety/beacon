import {drag, hierarchy, linkVertical, select, selectAll, tree} from "d3";
import { ajax } from "@rails/ujs";
export default class Tree {
  constructor(data, options = {}) {
    this.data = data;
    this.options = {
      width: 400,
      height: 200,
      nodeRadius: 14,
      ...options
    };
    this.isDragging = false;
    this.newParent = null;
  }

  draw() {
    this.root = hierarchy(this.data);
    const treeLayout = tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    const {width, height, nodeRadius} = this.options;

    this.treeSvg = select('.tree')
      .attr('width', width + nodeRadius*2)
      .attr('height', height + nodeRadius*2)
      .attr('viewBox', `0 0 ${width + nodeRadius*2 + 6} ${height}`);

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
        .attr("id", d => `goal_${d.data.id}`)
        .call(drag()
          .on("start", function(event) { self.dragStarted(event, this); })
          .on("drag", function(event) { self.drag(event, this); })
          .on("end", function(event) { self.dragEnd(event, this); })
        )
        .on('mouseenter', function(event) { self.mouseEnter(event, this); })
        .on('mouseleave', function(event) { self.mouseLeave(event, this); });

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
      ...descendants.map(d => select(`#goal_${d.data.id}`)),
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
      this.reparent(svg.datum(), this.newParent.datum());
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
      const t = this.newParent.transition().duration(150);
      // this.newParent.classed('hovering', false);
      this.newParent
        .transition(t)
        .attr("transform", 'scale(1)');
      this.newParent = null;
    }
  }

  async reparent(draggingDatum, newParentDatum) {
    this.data = await this.reparentServerSide(draggingDatum.data.id, newParentDatum.data.id);
    this.draw();
  }

  async reparentServerSide(goal_id, new_parent_id) {
    return new Promise((fulfill, reject) => {
      ajax({
        url: `/goals/${encodeURIComponent(goal_id)}/reparent/${encodeURIComponent(new_parent_id)}`,
        type: 'PUT',
        success: data => {
          fulfill(data);
        }
      });
    });
  }
}
