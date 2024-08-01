import { ProjectItem } from "../app/page";

type ProjectListItemProps = {
  project: ProjectItem
}

const ProjectListItem = ({ project }: ProjectListItemProps) => {
  return (
    <div className="flex flex-row p-4 gap-4 min-w-400 border border-sky-500 max-w-4xl">
      <img src={project.image} />

      <div className="flex flex-col items-start gap-2">
        <h1 className="text-lg font-bold">{project.name}</h1>
        <p>{project.description}</p>
        <div>
          {project.raised} / {project.target} BTC
        </div>
        <div>Close Date: {project.closeDate}</div>
        <button
          type="button"
          className="inline-block text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800">
          Fund
        </button>
      </div>
    </div>
  );
};

export default ProjectListItem;