import * as d3 from "d3";

export default class Tree {
  constructor(data, options = {}) {
    this.data = data;
    this.options = {
      width: 400,
      height: 200,
      ...options
    };
  }

  draw() {
    this.root = d3.hierarchy(this.data);

    const treeLayout = d3.tree();
    treeLayout.size([this.options.width, this.options.height]);
    treeLayout(this.root);

    this.tree = d3.select('#tree')
      .attr('width', 500)
      .attr('height', 500);
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
      .classed("node", true);
    // .call(handleEvents)

    treeNodes
      .append("circle")
      .classed("the-node solid", true)
      .attr("cx", d => d.x)
      .attr("cy", d => d.y)
      .attr("r", () => 14)
      .style("fill", "#696969");

    treeNodes
      .append("text")
      .attr("class", "label")
      .attr("dx", (d) => d.x)
      .attr("dy", (d) => d.y + 4)
      .text((d) => d.data.name);
  }

  drawVertices() {
    
    this.tree.select('g.links')
      .attr("fill", "none")
      .attr("stroke", "#555")
      .attr("stroke-opacity", 0.4)
      .attr("stroke-width", 1.5)
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
