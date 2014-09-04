
wordWidth = 80
wordHeight = 20
levelHeight = (level) -> 2 + Math.pow(level, 1.8) * 10

window.drawTree = (svgElement, conllData) ->
        svg = d3.select(svgElement)
        data = parseConll2009(conllData)

        # compute edge levels
        edges = (item for item in data when item.id)
        for edge in edges
                for edge in edges
                        edge.level = 1 + maximum(e.level for e in edges when under(edge, e))

        # compute height
        treeWidth = wordWidth*data.length - wordWidth/3
        treeHeight = levelHeight(maximum(edge.level for edge in data)) + 2 * wordHeight
        for item in data
                item.bottom = treeHeight - 1.8 * wordHeight
                item.top = item.bottom - levelHeight(item.level)
                item.left = item.id * wordWidth
                item.right = item.parent * wordWidth
                item.mid = (item.right+item.left)/2
                item.diff = (item.right-item.left)/4
                item.arrow = item.top + (item.bottom-item.top)*.25

        # draw svg
        svg.selectAll('text, path').remove()
        svg.attr('width', treeWidth + 2*wordWidth/3).attr('height', treeHeight + wordHeight/2)

        words = svg.selectAll('.word').data(data).enter()
                .append('text')
                .text((d) -> d.word)
                .attr('class', (d) -> "word w#{d.id}")
                .attr('x', (d) -> wordWidth*d.id)
                .attr('y', treeHeight-wordHeight)
                .on 'mouseover', (d) ->
                        svg.selectAll('.word, .dependency, .edge, .arrow').classed('active', false)
                        svg.selectAll('.tag').attr('opacity', 0)
                        svg.selectAll(".w#{d.id}").classed('active', true)
                        svg.select(".tag.w#{d.id}").attr('opacity', 1)
                .on 'mouseout', (d) ->
                        svg.selectAll('.word, .dependency, .edge, .arrow').classed('active', false)
                        svg.selectAll('.tag').attr('opacity', 0)

        tags = svg.selectAll('.tag').data(data).enter()
                .append('text')
                .text((d) -> d.tag)
                .attr('class', (d) -> "tag w#{d.id}")
                .attr('x', (d) -> treeWidth - wordWidth*d.id)
                .attr('y', treeHeight)
                .attr('opacity', 0)

        edges = svg.selectAll('.edge').data(data).enter()
                .append('path')
                .filter((d) -> d.id)
                .attr('class', (d) -> "edge w#{d.id} w#{d.parent}")
                .attr('d', (d) -> "M#{d.left},#{d.bottom} C#{d.mid-d.diff},#{d.top} #{d.mid+d.diff},#{d.top} #{d.right},#{d.bottom}")

        dependencies = svg.selectAll('.dependency').data(data).enter()
                .append('text')
                .filter((d) -> d.id)
                .text((d) -> d.dependency)
                .attr('class', (d) -> "dependency w#{d.id} w#{d.parent}")
                .attr('x', (d) -> d.mid)
                .attr('y', (d) -> d.arrow - 7)

        triangle = d3.svg.symbol().type('triangle-up').size(5)
        arrows = svg.selectAll('.arrow').data(data).enter()
                .append('path')
                .filter((d) -> d.id)
                .attr('class', (d) -> "arrow w#{d.id} w#{d.parent}")
                .attr('d', triangle)
                .attr('transform', (d) -> "translate(#{d.mid}, #{d.arrow}) rotate(#{if d.id < d.parent then '' else '-'}90)")


# functions
maximum = (array) -> Math.max 0, Math.max.apply(null, array);

under = (edge1, edge2) ->
        [mi, ma] = if edge1.id < edge1.parent then [edge1.id, edge1.parent] else [edge1.parent, edge1.id]
        edge1.id != edge2.id and edge2.id >= mi and edge2.parent >= mi and edge2.id <= ma and edge2.parent <= ma

parseConll = (conllData) ->
        data = []
        data.push id: 0, word: 'ROOT', tag: 'ROOT', level: 0
        for line in conllData.split('\n') when line
                [id, word, _, cpos, fpos, _, parent, dependency] = line.split('\t')
                tag = if cpos != fpos then cpos+' '+fpos else cpos
                data.push id: Number(id), word: word, tag: tag, parent: Number(parent), dependency: dependency, level: 1
        data


parseConll2009 = (conllData) ->
        data = []
        data.push id: 0, word: 'ROOT', tag: 'ROOT', level: 0
        for line in conllData.split('\n') when line
                [id, word, _, _, pos, ppos, _, _, head, phead, deprel, pdeprel, _, _] = line.split('\t')
                tag = ppos
                data.push id: Number(id), word: word, tag: tag, parent: Number(phead), dependency: pdeprel, level: 1
        data
