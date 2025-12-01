#include <stdio.h>

void part_1() {
    int pos = 50;
    int zero_count = 0;
    char direction;
    int steps;
    FILE *fptr = fopen("operations.txt", "r");

    while (fscanf(fptr, " %c%d", &direction, &steps) == 2) {
        if (direction == 'R') {
            int new_pos = pos + steps;
            pos = new_pos - (new_pos / 100) * 100;
        } else {
            int new_pos = pos - steps;
            while (new_pos < 0) new_pos += 100;
            pos = new_pos;
        }

        if (pos == 0) {
            zero_count++;
        }
    }

    fclose(fptr);
    printf("0s %d\n", zero_count);
}

void part_2() {
    int pos = 50;
    int zero_count = 0;
    char direction;
    int steps;
    FILE *fptr = fopen("operations.txt", "r");

    while (fscanf(fptr, " %c%d", &direction, &steps) == 2) {
        if (direction == 'R') {
            zero_count += (pos + steps) / 100;
            pos = (pos + steps) % 100;
        } else {
            if (pos == 0) {
                zero_count += steps / 100;
            } else if (steps >= pos) {
                zero_count += (steps - pos) / 100 + 1;
            }
            pos = ((pos - steps) % 100 + 100) % 100;
        }
    }

    fclose(fptr);
    printf("0s hit total %d\n", zero_count);
}

int main() {
    part_1();
    part_2();
    return 0;
}
