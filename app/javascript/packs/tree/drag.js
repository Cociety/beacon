import { drag, select, selectAll } from "d3";
import BeaconApi from "../beacon_api";

let isDragging = false;
let newParent = null;
let nodesBeingDrug = null;
const beaconApi = new BeaconApi();

function dragStarted(event) {
  isDragging = true;
  const descendants = event.subject.descendants();
  nodesBeingDrug = [
    ...descendants.map(d => select(`#node_${d.data.id}`)),
    ...descendants.map(d => selectAll(`[id^="link_${d.data.id}"]`))
  ];
  
}

function drug(event) {
  nodesBeingDrug.forEach(n => {
    n.classed("dragging", true)
     .raise()
     .attr("transform", `translate(${event.x - event.subject.x}, ${event.y - event.subject.y})`);
  });
}

function dragEnd(_, g) {
  isDragging = false;
  if (newParent) {
    const svg = select(g);
    beaconApi.adopt(newParent.datum().data.id, svg.datum().data.id);
  } else {
    nodesBeingDrug.forEach(n => {
      n.attr("transform", null);
    });
  }

  nodesBeingDrug.forEach(n => n.classed("dragging", false));
  resetNewParent();
}

export function mouseEnter(_, g) {
  if (isDragging) {
    newParent = select(g);
    newParent.classed('hovering', true);
    const t = newParent.transition().duration(150);
    newParent
      .transition(t)
      .attr("transform", d => `translate(${d.x}, ${d.y}) scale(1.1, 1.1) translate(${-d.x}, ${-d.y})`);
  }
}

export function mouseLeave() {
  if (isDragging) {
    resetNewParent();
  }
}

function resetNewParent() {
  if (newParent) {
    newParent.classed('hovering', false);
    const t = newParent.transition().duration(150);
    // newParent.classed('hovering', false);
    newParent
      .transition(t)
      .attr("transform", 'scale(1)');
    newParent = null;
  }
}

export function dragHandler(nodes) {
  nodes.on('mouseenter', function(event) { mouseEnter(event, this); })
       .on('mouseleave', function(event) { mouseLeave(event, this); });
  
  const makeDraggable = drag()
    .on("start", function(event) { dragStarted(event, this); })
    .on("drag", function(event) { drug(event, this); })
    .on("end", function(event) { dragEnd(event, this); });

  makeDraggable(nodes);
}