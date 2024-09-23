<?php
namespace Edu\Easily\Console;


use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use function Laravel\Prompts\confirm;
use function Laravel\Prompts\multiselect;
use function Laravel\Prompts\select;
use function Laravel\Prompts\text;

class EasilyCreate extends Command
{
    use Concerns\ConfiguresPrompts;
    protected function configure()
    {
        $this
            ->setName('create')
            ->setDescription('Creates a project for the current folder')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $directory = getcwd();

        dd($directory);
    }
}
