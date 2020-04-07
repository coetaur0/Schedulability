import ArgumentParser
import SchedulabilityLib

struct SchedulabilityCommand: ParsableCommand {
  
  @Argument(default: nil, help: "The path to a configuration file describing a task model")
  var configurationFile: String
  
  /// Pretty print a scheduling.
  private func pprint(scheduling: [ScheduleKey : ScheduleValue]) {
    let tasks = scheduling.keys.filter({ $0.isTaskID })

    // Print the current clock of each core.
    for coreKey in scheduling.keys.filter({ $0.isCoreID }).sorted() {
      print("\(coreKey) @ \(scheduling[coreKey]!.clock): ", terminator: "")

      // Identify the tasks that are scheduled on the current core and order them according to the
      // scheduled execution order.
      let coreTasks = tasks.filter({ scheduling[$0]?.coreID == coreKey.coreID })
        .sorted(by: { a, b in
          scheduling[a]!.clock < scheduling[b]!.clock
        })

      print(coreTasks.map({ "t\($0.taskID):\(scheduling[$0]!.clock)" }).joined(separator: ", "))
    }
  }
  
  func run() throws {
    let factory = ScheduleSet.Factory()
    let model = try TaskModel(from: configurationFile)
    
    let schedulings = model.schedulings(coreCount: 2, with: factory)
    print("Number of possible schedulings: \(schedulings.count)")
    print("Number of nodes created: \(factory.createdCount)\n")

    //print(schedulings.randomElement() as Any)
    //if let scheduling = schedulings.randomElement() {
    //  print(scheduling: scheduling)
    //}
    for scheduling in schedulings {
      pprint(scheduling: scheduling)
      print()
    }
  }
  
}

SchedulabilityCommand.main()
