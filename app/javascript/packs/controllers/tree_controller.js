import { Controller } from "stimulus";
import { hierarchy, linkVertical, select, tree } from "d3";
import { dragHandler } from "../tree/drag";

export default class TreeController extends Controller {
  static values = { hierarchy: Object };
  static targets = [ "tree" ];

  initialize() {
    this.options = {
      height: 600,
      nodeRadius: 40,
      width: null,
      avatarRadius: 12
    }
    this.draw();
  }

  draw() {
    this.options.width = this.treeTarget.offsetWidth;
    if (!this.isInitialized) {
      this.isInitialized = true;

      // re-render on window resize
      window.addEventListener("resize", () => this.draw());
    }
    this.root = hierarchy(this.hierarchyValue);
    const treeLayout = tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    const { width, height, nodeRadius, avatarRadius } = this.options;

    const viewBoxPadding = nodeRadius * 2 + avatarRadius;
    this.treeSvg = select('.tree')
      .attr('width', width + viewBoxPadding)
      .attr('height', height + viewBoxPadding)
      .attr('viewBox', `0 0 ${width + viewBoxPadding} ${height}`)

    this.treeSvg.selectAll("g.node").remove();
    this.treeSvg.selectAll("path.link").remove();
    this.datums = this.uniqueDatums();
    this.drawNodes();
    this.drawVertices();
  }

  drawNodes() {
    const self = this;
    const { nodeRadius, avatarRadius } = this.options;
    this.nodes = this.treeSvg
      .select("g.nodes")
      .selectAll("g")
      .data(this.datums)
      .join("g")
        .classed("node", true)
        .attr("id", d => `node_${d.data.id}`)
        .call(dragHandler)
        .each(function() {
          const node = select(this);
          node.datum().data.hasBlockedChildren = self.hasBlockedChildren(node.datum());
        });

    this.nodes
      .append("foreignObject")
      .attr("x", d => d.x - nodeRadius)
      .attr("y", d => d.y - nodeRadius)
      .attr('height', nodeRadius*2)
      .attr('width', nodeRadius*2)
      .append('xhtml:a')
      .attr('href', d => `/goals/${encodeURIComponent(d.data.id)}`)
      .classed('goal', true)
      .each(function() {
        const node = select(this);
        const data = node.datum().data;
        const state = data.hasBlockedChildren ? "blocked" : data.state;
        node.classed(state, true);
      })
      .append("xhtml:p")
      .classed("label", true)
      .text(d => d.data.name);

    this.nodes.each(function() {
      const node = select(this);
      const data = node.datum().data;
      if (data.assignee) {
        node.append('svg:image')
            .attr("x", d => d.x + nodeRadius - avatarRadius)
            .attr("y", d => d.y - nodeRadius - avatarRadius/2)
            .attr('xlink:href', data.assignee.avatar_url)
            .classed("avatar", true)
            .attr('style', `width: ${avatarRadius*2}px; height: ${avatarRadius*2}px`)
      }
    });
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