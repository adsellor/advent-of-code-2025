from collections import Counter
from itertools import combinations


def parse(data):
    boxes = []
    for line in data.strip().splitlines():
        x, y, z = map(int, line.split(","))
        boxes.append((x, y, z))
    return boxes


def dist(a, b):
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def part1(data, num_connections):
    boxes = parse(data)
    n = len(boxes)
    pairs = sorted(
        (dist(boxes[i], boxes[j]), i, j) for i, j in combinations(range(n), 2)
    )
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        parent[find(x)] = find(y)

    for _, i, j in pairs[:num_connections]:
        union(i, j)

    sizes = sorted(Counter(find(i) for i in range(n)).values(), reverse=True)
    return sizes[0] * sizes[1] * sizes[2]


def part2(data):
    boxes = parse(data)
    n = len(boxes)
    pairs = sorted(
        (dist(boxes[i], boxes[j]), i, j) for i, j in combinations(range(n), 2)
    )
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        parent[px] = py
        return True

    merges = 0
    for _, i, j in pairs:
        if union(i, j):
            merges += 1
            if merges == n - 1:
                return boxes[i][0] * boxes[j][0]


if __name__ == "__main__":
    data = open("./boxes.txt", "r").read()

    print("part1 ", part1(data, 1000))
    print("part2 ", part2(data))
