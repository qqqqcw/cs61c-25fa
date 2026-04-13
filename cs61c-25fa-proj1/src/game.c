#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  // TODO: Implement this function.
  game_t *g = malloc(sizeof(game_t));
  g->num_rows = 18;
  g->board = malloc(g->num_rows * sizeof(char *));
  for (int i = 0; i < g->num_rows; i++) {
    g->board[i] = malloc(22 * sizeof(char)); //为换行符留位置
  }
  
  for(int i = 0; i < 20; i++) {
    for(int j = 0; j < 18; j++) {
      g->board[j][i] = ' ';
    }
    g->board[0][i] = '#';
    g->board[17][i] = '#';
  }
  for(int i = 1; i < 17; i++) {
    g->board[i][0] = '#';
    g->board[i][19] = '#';
  }
  for(int i = 0; i < 18; i++) {
    g->board[i][20] = '\n';
    g->board[i][21] = '\0';
  }
  g->board[2][9] = '*';
  g->board[2][2] = 'd';
  g->board[2][4] = 'D';
  g->board[2][3] = '>';
  g->num_snakes = 1;
  g->snakes = malloc(sizeof(snake_t));
  g->snakes->head_col = 4;
  g->snakes->head_row = 2;
  g->snakes->tail_col = 2;
  g->snakes->tail_row = 2;
  g->snakes->live = true;
  return g;
}

/* Task 2 */
void free_game(game_t *game) {
  // TODO: Implement this function.
  free(game->snakes);
  for(int i = 0; i < game->num_rows; i++) {
    free(game->board[i]);
  }
  free(game->board);
  free(game);

}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  // TODO: Implement this function.
  for(int i = 0; i < game->num_rows; i++) {
    int j = 0;
    while(game->board[i][j] != '\n') {
      fprintf(fp, "%c", game->board[i][j]);
      j++;
    }
    fprintf(fp, "%c", game->board[i][j]);
  }
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  return c == 'w' || c == 'a' || c == 's' || c == 'd';
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  return c == 'W' || c == 'A' || c == 'S' || c == 'D' || c =='x';
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  char *a = "wasd^<v>WASDx";
  return strchr(a, c) != NULL;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  char t;
  switch (c)
  {
  case '^' : 
    t = 'w';
    break;
  case '<' : 
    t = 'a';
    break;
  case '>' : 
    t = 'd';
    break;
  case 'v' : 
    t = 's';
    break;
  default:
  t = NULL;
    break;
  }
  return t;
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  char t;
  switch (c)
  {
  case 'W' : 
    t = '^';
    break;
  case 'A' : 
    t = '<';
    break;
  case 'D' : 
    t = '>';
    break;
  case 'S' : 
    t = 'v';
    break;
  default:
  t = NULL;
    break;
  }
  return t;
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  unsigned int next_row;
  switch (c)
  {
  case 'v' : 
  case 's' : 
  case 'S' : 
    next_row = cur_row + 1;
    break;
  case '^' : 
  case 'w' : 
  case 'W' : 
    next_row = cur_row - 1;
    break;
  default :
    next_row = cur_row;
  }
  return next_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  unsigned int next_col;
  switch (c)
  {
  case '>' : 
  case 'd' : 
  case 'D' : 
    next_col = cur_col + 1;
    break;
  case '<' : 
  case 'a' : 
  case 'A' : 
    next_col = cur_col - 1;
    break;
  default :
  next_col = cur_col;
  }
  return next_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  char head_c = get_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col);
  return get_board_at(game, get_next_row(game->snakes[snum].head_row, head_c), get_next_col(game->snakes[snum].head_col, head_c));
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  char head_c = get_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col);
  set_board_at(game, get_next_row(game->snakes[snum].head_row, head_c), get_next_col(game->snakes[snum].head_col, head_c), head_c);
  set_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col, head_to_body(head_c));
  game->snakes[snum].head_col = get_next_col(game->snakes[snum].head_col, head_c);
  game->snakes[snum].head_row = get_next_row(game->snakes[snum].head_row, head_c);
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
    char tail_c = get_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col);
    char body_c = get_board_at(game, get_next_row(game->snakes[snum].tail_row, tail_c), get_next_col(game->snakes[snum].tail_col, tail_c));
  set_board_at(game, game->snakes[snum].tail_row, game->snakes[snum].tail_col, ' ');
  set_board_at(game, get_next_row(game->snakes[snum].tail_row, tail_c), get_next_col(game->snakes[snum].tail_col, tail_c), body_to_tail(body_c));
  game->snakes[snum].tail_col =get_next_col(game->snakes[snum].tail_col, tail_c);
  game->snakes[snum].tail_row = get_next_row(game->snakes[snum].tail_row, tail_c);
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  // TODO: Implement this function.
  for (unsigned int snum = 0;snum < game->num_snakes; snum++) {
    char head_c = get_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col);
    unsigned int next_head_row = get_next_row(game->snakes[snum].head_row, head_c);
    unsigned int next_head_col = get_next_col(game->snakes[snum].head_col, head_c);
    switch (game->board[next_head_row][next_head_col])
    {
    case '*':
      update_head(game, snum);
      add_food(game);
      break;
    case '#':
    case '^':
    case '>':
    case '<':
    case 'v':
      set_board_at(game, game->snakes[snum].head_row, game->snakes[snum].head_col, 'x');
      game->snakes[snum].live = false;
      break;
    case ' ':
      update_head(game, snum);
      update_tail(game, snum);
      break;
    }
  }
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  // TODO: Implement this function.
  size_t size = 22;
  size_t len = 0;
  char * line = malloc(size);
  if(line ==NULL) {
    return NULL;
  }
  line[0] = '\0';
  while(1) {
    if (size - len < 2) {
      size *= 2;
      char * new_line = realloc(line, size);
      if (new_line == NULL) {
        free(line);
        return NULL;
      }
      line = new_line;
    }
    char *s = line + len;
    if (fgets(s, (int)(size - len), fp) == NULL) {
      if (len == 0) {
        free(line);
        return NULL;
      }
      break;
    }
    len += strlen(s);
    if (strchr(s, '\n') != NULL) {
        break;
    }
  }
  return line;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  game_t *g = malloc(sizeof(game_t));
  g->num_rows = 0;
  g->num_snakes = 0;
  g->snakes = NULL;
  size_t size = 18;
  g->board = malloc(size * sizeof(char *));
  char *line;
  while ((line = read_line(fp)) != NULL) {
    if (size - g->num_rows < 2) {
      size *= 2;
      char **new_board = realloc(g->board, size * sizeof(char *));
      g->board = new_board;
    }
    g->board[g->num_rows] = line;
    g->num_rows++;
  }
  return g;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int cur_row = game->snakes[snum].tail_row;
  unsigned int cur_col = game->snakes[snum].tail_col;
  char cur_squre = get_board_at(game, cur_row, cur_col);
  while(1) {
    cur_row = get_next_row(cur_row, cur_squre);
    cur_col = get_next_col(cur_col, cur_squre);
    cur_squre = get_board_at(game, cur_row, cur_col);
    if(is_head(cur_squre)) {
      break;
    }
  }
  game->snakes[snum].head_row = cur_row;
  game->snakes[snum].head_col = cur_col;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  // TODO: Implement this function.
  game->num_snakes = 0;
  for (unsigned int i = 0; i < game->num_rows; i++) {
    unsigned int j = 0;
    while (game->board[i][j] != '\n') {
      if (is_tail(game->board[i][j])) {
        game->num_snakes++;
        game->snakes = realloc(game->snakes, game->num_snakes * sizeof(snake_t));
        game->snakes[game->num_snakes - 1].tail_col = j;
        game->snakes[game->num_snakes - 1].tail_row = i;   
        game->snakes[game->num_snakes - 1].live = true;     
        find_head(game, game->num_snakes - 1);
      }
      j++;
    }

  }
  return game;
}
