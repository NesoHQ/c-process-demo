## 🧠 Process Memory & Forking — Educational Guide

### 🔹 `cow.c`: **Demonstrating Copy-On-Write (COW)**

**What it does:**

- Allocates and initializes **10MB** of memory (`buffer`) before calling `fork()`.
- After the fork:

    - The **parent** modifies `buffer[0]++`.
    - The **child** modifies different parts of the buffer (`buffer[(i++)*1000]++`).

- Both run indefinitely and print their PID, buffer value, and (in child) a variable `Y`.

**What it teaches:**

- **Memory is shared (logically)** between parent and child immediately after a `fork()` — **but** it's **copy-on-write**:

    - At first, both processes point to the same physical pages.
    - When either process modifies the memory, the OS creates a **private copy** of the modified page (a **COW page fault** occurs).

- By observing `/proc/<pid>/smaps`, you’ll see how the **heap diverges** between parent and child after writes.
- Also teaches:

    - Infinite looping processes
    - Manual memory management
    - Inter-process memory divergence

---

### 🔹 `nofork.c`: **Single Process with Memory Allocation**

**What it does:**

- Allocates 10MB of memory (uninitialized because `memset` is commented out).
- Runs an infinite loop **without any `fork()`**, printing the process PID and buffer\[0].

**What it teaches:**

- The **baseline behavior** of a process that owns and manages memory entirely.
- Memory is **never duplicated**, no children exist.
- Shows that a single process can safely allocate and hold memory without OS intervention for copy or protection.
- Great to **compare** with `cow.c` — you'll notice:

    - No `/proc` memory growth
    - Heap doesn't change across processes (there’s only one process)
    - Demonstrates **what happens without `fork()`**

---

### 🔹 `p.c`: **Forking Without Writing — Shared Pages Stay Shared**

**What it does:**

- Allocates and initializes 10MB of memory with `memset`.
- Calls `fork()`, creating a parent and a child.
- **Neither process modifies the memory.**
- Both processes loop infinitely and print `buffer[0]`, but the modification lines are commented out.

**What it teaches:**

- The **ultimate illustration of how Copy-On-Write works**:

    - If neither process writes to shared memory, they **share the same physical pages** forever.
    - `/proc/<pid>/smaps` will show **shared heap pages**.

- Compared to `cow.c`, this program shows **no page duplication**, because no writes happen.
- Helps highlight how **lazy memory duplication** is in modern OSes.
- Also shows that just reading shared memory does **not** trigger COW.

---

## 🧪 Use Case in Docker + entrypoint Shell

With your interactive Docker shell setup, you can:

| Command            | What it demonstrates                                  |
| ------------------ | ----------------------------------------------------- |
| `cow run`          | Triggers COW behavior through real-time memory writes |
| `show cow-heap`    | Shows how heap splits between parent and child        |
| `nofork run`       | Shows single-process memory footprint                 |
| `show nofork-heap` | Shows memory map of a lone process                    |
| `p run`            | Shows how memory is shared when no writing occurs     |
| `show p-heap`      | Demonstrates shared heap due to read-only behavior    |

---

## 🧠 Summary Table

| File       | fork()? | Writes to Memory? | Demonstrates                  |
| ---------- | ------- | ----------------- | ----------------------------- |
| `cow.c`    | ✅      | ✅                | **Copy-On-Write in action**   |
| `nofork.c` | ❌      | ❌                | **Single process baseline**   |
| `p.c`      | ✅      | ❌                | **Shared memory with no COW** |

---

## 📌 Suggested Exercises

1. **Run `p run`, inspect smaps**:

    - `cat /proc/<pid>/smaps | grep Rss`
    - Should show **minimal duplicated pages**.

2. **Run `cow run`, inspect smaps for both**:

    - Run `show cow-heap`
    - See how buffer modification creates **different memory mappings**.

3. **Log outputs with `log cow` / `log p`**:

    - Observe behavior of each process’s output.
