import * as d3 from "d3";

const LINK_STYLES = {
  "наследование": {color: "#10b981", dash: null},
  "вдохновение": {color: "#f59e0b", dash: "6,4"},
  "сборка": {color: "#3b82f6", dash: "2,3"},
  "форк": {color: "#8b5cf6", dash: "4,4"},
};

export const GenealogyGraph = {
  mounted() {
    this.highlighted = new Set();
    this.initSvg();
    this.render();
    this.handleEvent("highlight_path", ({node_ids}) => this.highlightNodes(node_ids || []));
  },

  updated() {
    this.render();
  },

  initSvg() {
    this.width = this.el.clientWidth || 800;
    this.height = this.el.clientHeight || 600;

    this.svg = d3
      .select(this.el)
      .html("")
      .append("svg")
      .attr("width", this.width)
      .attr("height", this.height);

    this.g = this.svg.append("g");
    this.linkLayer = this.g.append("g").attr("stroke-opacity", 0.7);
    this.nodeLayer = this.g.append("g");

    this.simulation = d3
      .forceSimulation()
      .force("link", d3.forceLink().id((d) => d.id).distance(120))
      .force("charge", d3.forceManyBody().strength(-400))
      .force("center", d3.forceCenter(this.width / 2, this.height / 2));
  },

  render() {
    const data = JSON.parse(this.el.dataset.graph || '{"nodes":[],"edges":[]}');
    const nodes = data.nodes.map((n) => ({...n}));
    const links = data.edges.map((e) => ({source: e.from, target: e.to, type: e.type}));

    const link = this.linkLayer
      .selectAll("line")
      .data(links, (d) => `${d.source}-${d.target}-${d.type}`)
      .join("line")
      .attr("stroke", (d) => (LINK_STYLES[d.type] || {}).color || "#94a3b8")
      .attr("stroke-dasharray", (d) => (LINK_STYLES[d.type] || {}).dash)
      .attr("stroke-width", 2);

    const node = this.nodeLayer
      .selectAll("g")
      .data(nodes, (d) => d.id)
      .join((enter) => {
        const g = enter
          .append("g")
          .attr("cursor", "pointer")
          .call(
            d3
              .drag()
              .on("start", (event, d) => {
                if (!event.active) this.simulation.alphaTarget(0.3).restart();
                d.fx = d.x;
                d.fy = d.y;
              })
              .on("drag", (event, d) => {
                d.fx = event.x;
                d.fy = event.y;
              })
              .on("end", (event, d) => {
                if (!event.active) this.simulation.alphaTarget(0);
                d.fx = null;
                d.fy = null;
              })
          )
          .on("click", (_, d) => this.pushEvent("select_node", {id: d.id}));

        g.append("circle").attr("r", 10).attr("fill", "#4f46e5");
        g.append("text")
          .attr("x", 14)
          .attr("y", 4)
          .attr("font-size", 11)
          .attr("fill", "#1f2937")
          .text((d) => d.label);

        return g;
      });

    node.select("circle").attr("stroke", (d) => (this.highlighted.has(d.id) ? "#f59e0b" : "none")).attr("stroke-width", 3);

    this.simulation.nodes(nodes).on("tick", () => {
      link
        .attr("x1", (d) => d.source.x)
        .attr("y1", (d) => d.source.y)
        .attr("x2", (d) => d.target.x)
        .attr("y2", (d) => d.target.y);

      node.attr("transform", (d) => `translate(${d.x},${d.y})`);
    });

    this.simulation.force("link").links(links);
    this.simulation.alpha(1).restart();
  },

  highlightNodes(ids) {
    this.highlighted = new Set(ids);
    this.render();
  },
};
