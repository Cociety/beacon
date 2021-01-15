import * as d3 from "d3";
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
    this.dragging = false;
    this.newParent = null;
  }

  draw() {
    this.root = d3.hierarchy(this.data);
    const treeLayout = d3.tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    const {width, height, nodeRadius} = this.options;

    this.treeSvg = d3.select('.tree')
      .attr('width', width + nodeRadius*2)
      .attr('height', height + nodeRadius*2)
      .attr('viewBox', `0 0 ${width + nodeRadius*2 + 6} ${height}`);

    this.treeSvg.selectAll("g.node").remove();
    this.treeSvg.selectAll("path.link").remove();
    this.nodes = this.uniqueNodes();
    this.drawNodes();
    this.drawVertices();
  }

  drawNodes() {
    const self = this;
    this.nodeElements = this.treeSvg
      .select("g.nodes")
      .selectAll("g")
      .data(this.nodes)
      .join("g")
        .classed("node", true)
        .call(d3.drag()
          .on("start", function(event) { self.dragStarted(event, this); })
          .on("drag", function(event) { self.dragged(event, this); })
          .on("end", function(event) { self.dragEnd(event, this); })
        )
        .on('mouseenter', function(event) { self.mouseEnter(event, this); })
        .on('mouseleave', function(event) { self.mouseLeave(event, this); });

    this.nodeElements
      .append("circle")
      .classed("circle", true)
      .attr("cx", d => d.x)
      .attr("cy", d => d.y)
      .attr("r", () => this.options.nodeRadius)
      .each(function() {
        const node = d3.select(this);
        const state = node.datum().data.state;
        node.classed(state, true);
      });

    this.nodeElements
      .append("foreignObject")
      .attr("x", d => d.x - this.options.nodeRadius)
      .attr("y", d => d.y - this.options.nodeRadius)
      .attr('height', this.options.nodeRadius*2)
      .attr('width', this.options.nodeRadius*2)
      .append("xhtml:p")
      .classed("label", true)
      .attr('draggable', true)
      .html(d => `<span aria-hidden="true"></span>${d.data.name}`);
  }

  drawVertices() {
    this.treeSvg.select('g.links')
      .selectAll("path")
      .data(this.links())
      .enter()
      .append("path")
      .classed("link", true)
      .join("path")
        .attr("d", d3.linkVertical()
            .x(d => d.x)
            .y(d => d.y));
  }

  uniqueNodes() {
    return Object.values(
      this.root.descendants().reduce((uniques, node) => {
        uniques[node.data.id] = node;
        return uniques;
      }, {})
    );
  }

  links() {
    return this.root.links(this.nodes).map(l => {
      l.target = this.nodes.find(n => n.data.id === l.target.data.id );
      return l;
    });
  }

  dragStarted(_, g) {
    this.dragging = true;
    d3.select(g)
      .classed("dragging", true)
      .raise();
  }
  
  dragged(event, g) {
    const svg = d3.select(g);
    const circle = svg.select('.circle');
    const text = svg.select('foreignObject');
    circle.attr("cx", event.x)
          .attr("cy", event.y);
    text.attr("x", event.x - this.options.nodeRadius)
        .attr("y", event.y - this.options.nodeRadius);
  }

  dragEnd(_, g) {
    this.dragging = false;
    const svg = d3.select(g);
    const circle = svg.select('.circle');
    const text = svg.select('foreignObject');
    if (this.newParent) {
      this.reparent(svg.datum(), this.newParent.datum());
    } else {
      const datum = svg.datum();
      circle.attr("cx", datum.x)
            .attr("cy", datum.y);

      text.attr("x", datum.x - this.options.nodeRadius)
          .attr("y", datum.y - this.options.nodeRadius);
    }

    svg.classed("dragging", false);
    this.resetNewParent();
  }

  mouseEnter(_, g) {
    if (this.dragging) {
      this.newParent = d3.select(g);
      const t = this.newParent.transition().duration(150);
      this.newParent
        .select('.circle')
        .transition(t)
        .attr("r", this.options.nodeRadius*1.1);
    }
  }

  mouseLeave() {
    if (this.dragging) {
      this.resetNewParent();
    }
  }

  resetNewParent() {
    if (this.newParent) {
      this.newParent
        .select('.circle')
        .attr("r", this.options.nodeRadius);
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
