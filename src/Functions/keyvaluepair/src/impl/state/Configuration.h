#pragma once

#include <vector>

namespace DB
{

struct ConfigurationFactory;

class Configuration
{
    friend struct ConfigurationFactory;

    Configuration(
        char key_value_delimiter_,
        char quoting_character_,
        std::vector<char> pair_delimiters_
    );

public:
    const char key_value_delimiter;
    const char quoting_character;
    const std::vector<char> pair_delimiters;
};

struct ConfigurationFactory
{
public:
    static Configuration createWithoutEscaping(char key_value_delimiter, char quoting_character, std::vector<char> pair_delimiters);

    static Configuration createWithEscaping(char key_value_delimiter, char quoting_character, std::vector<char> pair_delimiters);

private:
    static void validate(char key_value_delimiter, char quoting_character, std::vector<char> pair_delimiters);
};

}
