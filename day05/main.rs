use std::fs;

fn main() {
    let fresh_input = fs::read_to_string("fresh.txt").unwrap();
    let ingredients_input = fs::read_to_string("ingredients.txt").unwrap();

    let ranges = parse_ranges(&fresh_input);
    let ids = parse_ids(&ingredients_input);

    let fresh_count = ids.iter().filter(|&id| is_fresh(*id, &ranges)).count();

    println!("Part 1: {}", fresh_count);

    let total_fresh = count_all_fresh(&ranges);
    println!("Part 2: {}", total_fresh);
}

fn parse_ranges(input: &str) -> Vec<(i64, i64)> {
    input
        .lines()
        .filter(|line| !line.is_empty())
        .map(|line| {
            let nums: Vec<i64> = line.split('-').map(|n| n.trim().parse().unwrap()).collect();
            (nums[0], nums[1])
        })
        .collect()
}

fn parse_ids(input: &str) -> Vec<i64> {
    input
        .lines()
        .filter(|line| !line.is_empty())
        .map(|line| line.trim().parse().unwrap())
        .collect()
}

fn is_fresh(id: i64, ranges: &[(i64, i64)]) -> bool {
    ranges.iter().any(|(start, end)| id >= *start && id <= *end)
}

fn count_all_fresh(ranges: &[(i64, i64)]) -> i64 {
    let merged = merge_ranges(ranges);
    merged.iter().map(|(start, end)| end - start + 1).sum()
}

fn merge_ranges(ranges: &[(i64, i64)]) -> Vec<(i64, i64)> {
    if ranges.is_empty() {
        return vec![];
    }
    let mut sorted = ranges.to_vec();
    sorted.sort_by_key(|r| r.0);
    let mut merged = vec![sorted[0]];

    for &(start, end) in &sorted[1..] {
        let last_idx = merged.len() - 1;
        let (last_start, last_end) = merged[last_idx];

        if start <= last_end + 1 {
            merged[last_idx] = (last_start, last_end.max(end));
        } else {
            merged.push((start, end));
        }
    }
    merged
}
