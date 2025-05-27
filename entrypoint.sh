#!/bin/bash
declare -A PIDS

show_help() {
    echo "🧠 Welcome to the C Process Demo Shell!"
    echo "================================================================"
    echo "Available commands:"
    echo "  readme              - show Readme documentation"
    echo "  cow run             - run cow.out (detached, COW demo)"
    echo "  nofork run          - run nofork.out (no fork demo)"
    echo "  p run               - run p.out (simple process)"
    echo
    echo "  show cow-heap       - show heap info of cow.out (parent & child)"
    echo "  show nofork-heap    - show heap info of nofork.out"
    echo "  show p-heap         - show heap info of p.out"
    echo
    echo "  cow close           - terminate cow.out (both parent & child)"
    echo "  nofork close        - terminate nofork.out"
    echo "  p close             - terminate p.out"
    echo
    echo "  log cow             - show last 20 lines of cow.out logs"
    echo "  log nofork          - show last 20 lines of nofork.out logs"
    echo "  log p               - show last 20 lines of p.out logs"
    echo
    echo "  clear               - clear the terminal screen"
    echo "  help                - show this help message again"
    echo "  exit                - exit the shell"
    echo "================================================================"
}

show_readme() {
    # Show README.md using bat if available
    if [ -f README.md ]; then
        echo "📘 Project README"
        echo "================================================================"
        if command -v bat &> /dev/null; then
            bat README.md
        else
            cat README.md
        fi
        echo "================================================================"
    fi
}

show_readme
show_help

while true; do
    read -rp "> " cmd args

    case $cmd in
        help)
            show_help
            ;;

        clear)
            clear
            ;;

        readme)
            show_readme
            ;;
        cow)
            case "$args" in
                run)
                    ./cow.out > cow.log 2>&1 &
                    parent_pid=$!
                    sleep 0.1
                    child_pid=$(pgrep -P $parent_pid)
                    PIDS[cow_parent]=$parent_pid
                    PIDS[cow_child]=$child_pid
                    echo "🐮 cow.out running:"
                    echo "   • Parent PID: $parent_pid"
                    echo "   • Child PID : $child_pid"
                    ;;
                close)
                    if [ -n "${PIDS[cow_parent]}" ]; then
                        kill "${PIDS[cow_parent]}" 2>/dev/null
                        kill "${PIDS[cow_child]}" 2>/dev/null
                        echo "💀 Terminated cow.out parent (${PIDS[cow_parent]}) and child (${PIDS[cow_child]})"
                        unset PIDS[cow_parent]
                        unset PIDS[cow_child]
                    else
                        echo "❗ cow is not running"
                    fi
                    ;;
                *)
                    echo "❓ Unknown cow command"
                    ;;
            esac
            ;;

        nofork)
            case "$args" in
                run)
                    ./nofork.out > nofork.log 2>&1 &
                    PIDS[nofork]=$!
                    echo "🚫 nofork.out running with PID ${PIDS[nofork]}"
                    ;;
                close)
                    if [ -n "${PIDS[nofork]}" ]; then
                        kill "${PIDS[nofork]}"
                        echo "💀 Terminated nofork.out (PID ${PIDS[nofork]})"
                        unset PIDS[nofork]
                    else
                        echo "❗ nofork is not running"
                    fi
                    ;;
                *)
                    echo "❓ Unknown nofork command"
                    ;;
            esac
            ;;

        p)
            case "$args" in
                run)
                    ./p.out > p.log 2>&1 &
                    PIDS[p]=$!
                    echo "🅿️  p.out running with PID ${PIDS[p]}"
                    ;;
                close)
                    if [ -n "${PIDS[p]}" ]; then
                        kill "${PIDS[p]}"
                        echo "💀 Terminated p.out (PID ${PIDS[p]})"
                        unset PIDS[p]
                    else
                        echo "❗ p is not running"
                    fi
                    ;;
                *)
                    echo "❓ Unknown p command"
                    ;;
            esac
            ;;

        show)
            case "$args" in
                cow-heap)
                    if [ -n "${PIDS[cow_parent]}" ]; then
                        echo "📦 cow.out Parent Heap:"
                        cat /proc/${PIDS[cow_parent]}/smaps | grep -A 50 heap
                        echo ""
                        echo "🍼 cow.out Child Heap:"
                        cat /proc/${PIDS[cow_child]}/smaps | grep -A 50 heap
                    else
                        echo "❗ cow is not running"
                    fi
                    ;;
                nofork-heap)
                    if [ -n "${PIDS[nofork]}" ]; then
                        echo "🚫 nofork.out Heap:"
                        cat /proc/${PIDS[nofork]}/smaps | grep -A 50 heap
                    else
                        echo "❗ nofork is not running"
                    fi
                    ;;
                p-heap)
                    if [ -n "${PIDS[p]}" ]; then
                        echo "🅿️  p.out Heap:"
                        cat /proc/${PIDS[p]}/smaps | grep -A 50 heap
                    else
                        echo "❗ p is not running"
                    fi
                    ;;
                *)
                    echo "❓ Unknown show command"
                    ;;
            esac
            ;;

        log)
            case "$args" in
                cow)
                    tail -n 20 cow.log 2>/dev/null || echo "❗ No log for cow"
                    ;;
                nofork)
                    tail -n 20 nofork.log 2>/dev/null || echo "❗ No log for nofork"
                    ;;
                p)
                    tail -n 20 p.log 2>/dev/null || echo "❗ No log for p"
                    ;;
                *)
                    echo "❓ Unknown log target"
                    ;;
            esac
            ;;

        exit)
            echo "👋 Exiting..."
            exit 0
            ;;

        *)
            echo "❌ Unknown command: $cmd"
            ;;
    esac
done
