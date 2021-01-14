import * as d3 from "d3";

export default class Tree {
  constructor(data, options = {}) {
    this.data = data;
    this.options = {
      width: 400,
      height: 200,
      nodeRadius: 14,
      ...options
    };
  }

  draw() {
    this.root = d3.hierarchy(this.data);

    const treeLayout = d3.tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    const {width, height, nodeRadius} = this.options;

    this.tree = d3.select('.tree')
      .attr('width', width + nodeRadius*2)
      .attr('height', height + nodeRadius*2)
      .attr('viewBox', `0 0 ${width + nodeRadius*2 + 6} ${height}`);
    // this.tree.select('g.transform')
    //   .attr('transform', `translate(0, ${nodeRadius*5})`);
    this.nodes = this.uniqueNodes();
    this.drawNodes();
    this.drawVertices();
  }

  drawNodes() {
    const treeNodes = this.tree
      .select('g.nodes')
      .selectAll("g.node")
      .data(this.nodes)
      .enter()
      .append("g")
      .classed("node", true)
      // .attr("requiredFeatures", "http://www.w3.org/Graphics/SVG/feature/1.2/#TextFlow");
    // .call(handleEvents)

    treeNodes
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

    treeNodes
      .append("foreignObject")
      .attr("x", d => d.x - this.options.nodeRadius)
      .attr("y", d => d.y - this.options.nodeRadius)
      .attr('height', this.options.nodeRadius*2)
      .attr('width', this.options.nodeRadius*2)
      .append("xhtml:p")
      .classed("label", true)
      .html(d => `<span aria-hidden="true"></span>${d.data.name}`);
  }

  drawVertices() {
    this.tree.select('g.links')
      .classed("link", true)
      .selectAll("path")
      .data(this.links())
      .enter()
      .append("path")
      // .classed("link", true)
      .join("path")
      .attr("d", d3.linkVertical()
          .x(d => d.x)
          .y(d => d.y));
  }

  uniqueNodes() {
    const uniqueNodes = Object.values(
      this.root.descendants().reduce((uniques, node) => {
        uniques[node.data.id] = node;
        return uniques;
      }, {})
    );

    return uniqueNodes;

    // recalculate the x poition of each of then node after the removal
    return uniqueNodes.map(n => {
      const nodesOfSameDepth = uniqueNodes.filter(un => un.depth === n.depth);
      const indexOfCurrent = nodesOfSameDepth.indexOf(n);
      const intervalPerDepth = this.options.height / nodesOfSameDepth.length;
      n.x = intervalPerDepth/2 + (intervalPerDepth * indexOfCurrent);
      return n;
    });
  }

  links() {
    return this.root.links(this.nodes).map(l => {
      console.log(this.nodes);
      l.target = this.nodes.find(n => n.data.id === l.target.data.id );
      return l;
    });
  }
}
